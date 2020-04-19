class PagesController < ApplicationController
  def home
  end

  def search
    @categories = Category.all
    @category = Category.find(params[:category]) if params[:category].present?

    query_condition = []
    query_condition[0] = "gigs.active = true"

    # Title filter
    @q = params[:q]
    if !@q.blank?
      query_condition[0] += " and gigs.title ILIKE ?"
      query_condition.push "%#{params[:q]}%"
    end

    # Category filter
    if !params[:category].blank?
      query_condition[0] += " and category_id = ?"
      query_condition.push params[:category]
    end

    # Min filter
    @min = params[:min]
    if !params[:min].blank?
      query_condition[0] += " and pricings.price >= ?"
      query_condition.push @min
    end

    # Max filter
    @max = params[:max]
    if !params[:max].blank?
      query_condition[0] += " and pricings.price <= ?"
      query_condition.push @max
    end

    # Delivery filter
    @delivery = params[:delivery].present? ? params[:delivery] : "0"
    if !params[:delivery].blank? && params[:delivery] != "0"
      query_condition[0] += " and pricings.delivery_time <= ?"
      query_condition.push @delivery
    end

    # Unique 
    query_condition[0] += " and ((gigs.has_single_pricing = true and pricings.pricing_type = 0) or (gigs.has_single_pricing = false))"

    # Sort by
    @sort = params[:sort].present? ? params[:sort] : "price asc"

    # Search
    @gigs = Gig
          .select("gigs.id, gigs.title, gigs.user_id, MIN(pricings.price) AS price")
          .joins(:pricings)
          .where(query_condition)
          .group("gigs.id")
          .order(@sort)
          .page(params[:page])
          .per(6)
  end

  def calendar
    params[:start_date] ||= Date.current.to_s

    start_date = Date.parse(params[:start_date])
    first_of_month = (start_date - 1.month).beginning_of_month
    end_of_month = (start_date + 1.month).end_of_month

    @orders = Order.where("seller_id = ? and status = ? and due_date between ? and ?",
                            current_user.id, 
                            Order.statuses[:inprogress],
                            first_of_month, 
                            end_of_month
                          )
  end

  def plans
    @plans = Stripe::Plan.list(product: 'prod_H7plWQbon608xp')
  end
end
