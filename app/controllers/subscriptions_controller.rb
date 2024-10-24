class SubscriptionsController < ApplicationController
    before_action :check_user, only: [:subscribe]
    skip_before_action :verify_authenticity_token, only: [:webhook]

    def check_user
        return if user_signed_in?
        redirect_to new_user_session_path, alert: 'Vous devez vous connecter ou vous inscrire avant de continuer.'
    end

    def subscribe
        if !current_user.stripe_id
            return redirect_to update_payment_path, alert: "Veuillez ajouter votre carte avant de vous abonner"
        end

        plan = Stripe::Plan.retrieve(params[:plan_id])
        if !plan.id 
            return redirect_to request.referrer, alert: "Plan non valide"
        end

        subscription = Subsription.exists?(user_id: current_user.id, status: Subsription.statuses[:success])
        if subscription.present?
            return redirect_to request.referrer, alert: "Vous ne pouvez pas souscrire à un autre plan"
        end

        # Create Stripe subscription
        stripe_sub = Stripe::Subscription.create(
            customer: current_user.stripe_id,
            items: [{plan: plan.id}]
        )

        # Create local subscription
        subscription = Subsription.create(
            user_id: current_user.id,
            plan_id: plan.id,
            sub_id: stripe_sub.id,
            expired_at: Date.current + 1.month,
        )

        return redirect_to dashboard_path, notice: "Abonnement réussi"
    end

    def webhook
        begin
            event_json = JSON.parse(request.body.read)
            event_object = event_json['data']['object']
            
            case event_json['type']
                when 'invoice.payment_succeeded'
                    stripe_sub_id = event_object['subscription']
                    subscription = Subsription.find_by_sub_id(stripe_sub_id)

                    if subscription.expired_at.nil?
                        expired_at = Date.current + 1.month
                    else
                        expired_at = subscription.expired_at + 1.month
                    end
                    subscription.update(status: Subsription.statuses[:success], expired_at: expired_at)

                when 'invoice.payment_failed'
                    stripe_sub_id = event_object['subscription']
                    subscription = Subsription.find_by_sub_id(stripe_sub_id)
                    subscription.update(status: Subsription.statuses[:pending])
                    
                when 'customer.subscription.deleted'
                    stripe_sub_id = event_object['id']
                    subscription = Subsription.find_by_sub_id(stripe_sub_id)
                    subscription.destroy
            end

        rescue Exception => e
            render :json => {status: 422, error: e}
            return
        end

        render :json => {status: 200}
    end

end