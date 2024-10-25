class UsersController < ApplicationController
  before_action :authenticate_user!

  def dashboard 
    @subscription = Subsription.find_by_user_id(current_user.id)
    if @subscription.present?
      @plan = Stripe::Plan.retrieve(@subscription.plan_id)
    end
  end

  def show
    @user = User.find(params[:id])
    @reviews = Review.where(seller_id: params[:id]).order("created_at desc")
  end

  def update
    @user = current_user
    if @user.update(current_users_params)
      flash[:notice] = "Sauvé."
    else
      flash[:alert] = "Impossible de mettre à jour."
    end
    redirect_to dashboard_path
  end

  def update_payment
    if !current_user.stripe_id
      customer = Stripe::Customer.create(
        email: current_user.email,
        source: params[:stripeToken]
      )
    else
      customer = Stripe::Customer.update(
        current_user.stripe_id,
        source: params[:stripeToken]
      )
    end

    if current_user.update(stripe_id: customer.id, stripe_last_4: customer.sources.data.first['last4'])
      flash[:notice] = "La nouvelle carte est enregistrée"
    else
      flash[:alert] = "Carte non valide"
    end
    redirect_to request.referrer
  rescue Stripe::CardError => e
    flash[:alert] = e.message
    redirect_to request.referrer
  end

  def update_payout
    if current_user.update(paypal: params['paypal'])
      flash[:notice] = "Mise à jour du paiement réussie"
    else
      flash[:error] = "Quelque chose n'a pas fonctionné"
    end
    redirect_to request.referrer
  end

  def earnings
    @net_income = (Transaction.where("seller_id = ?", current_user.id).sum(:amount) / 1.1).round(2)

    @withdrawn = Transaction.where("buyer_id = ? AND status = ? and transaction_type = ?", 
                    current_user.id, 
                    Transaction.statuses[:approved],
                    Transaction.transaction_types[:withdraw]
                  ).sum(:amount)

    @pending = Transaction.where("buyer_id = ? AND status = ? and transaction_type = ?", 
                current_user.id, 
                Transaction.statuses[:pending],
                Transaction.transaction_types[:withdraw]
              ).sum(:amount)

    @purchased = Transaction.where("buyer_id = ? AND source_type = ? and transaction_type = ?", 
                  current_user.id, 
                  Transaction.source_types[:system],
                  Transaction.transaction_types[:trans]
                ).sum(:amount)

    @withdrawable = current_user.wallet

    @transactions = Transaction.where("seller_id = ? OR (buyer_id = ? AND source_type = ?)", 
                      current_user.id,
                      current_user.id,
                      Transaction.source_types[:system]
                    ).page(params[:page])
  end

  def withdraw
    amount = params[:amount].to_i
    is_pending_withdraw = Transaction.exists?(buyer_id: current_user.id, 
                                              status: Transaction.statuses[:pending], 
                                              transaction_type: Transaction.transaction_types[:withdraw]
                                             )
    
    if amount <= 0
      flash[:alert] = "Montant non valide"
    elsif amount > current_user.wallet
      flash[:alert] = "Vous demandez plus que ce que vous avez"
    elsif !is_pending_withdraw.blank?
      flash[:alert] = "Vous avez une demande de retrait en cours"
    else
      transaction = Transaction.new
      transaction.status = Transaction.statuses[:pending]
      transaction.transaction_type = Transaction.transaction_types[:withdraw]
      transaction.source_type = Transaction.source_types[:system]
      transaction.buyer = current_user
      transaction.amount = amount

      if transaction.save
        flash[:notice] = "Demande de retrait créée avec succès"
      else
        flash[:alert] = "Impossible de créer une demande"
      end
    end

    redirect_to request.referrer
  end

  def remove_subscription
    @subscription = Subsription.find_by_user_id(current_user.id)

    if @subscription.present? && @subscription.sub_id
      Stripe::Subscription.delete(@subscription.sub_id)
      return redirect_to request.referrer, notice: "Votre abonnement est annulé"
    end
    return redirect_to request.referrer, alert: "Impossible d'annuler votre abonnement"
  end

  private
  def current_users_params
    params.require(:user).permit(:from, :about, :status, :language, :avatar)
  end
end
