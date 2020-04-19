class CommentsController < ApplicationController
    before_action :authenticate_user!
    before_action :is_valid_order
    
    def create
        order = Order.find(comments_params[:order_id])

        if comments_params[:content].blank?
            # return redirect_to request.referrer, alert: "Invalid message"
            return render json: {success: false}
        end

        if order.buyer_id != current_user.id && order.seller_id != current_user.id
            return render json: {success: false}
        end

        @comment = Comment.new(
            user_id: current_user.id,
            order_id: order.id,
            content: comments_params[:content],
            attachment_file: comments_params[:attachment_file]
        )

        if @comment.save
            # redirect_to request.referrer, notice: "Comment sent..."
            CommentChannel.broadcast_to order, message: render_comment(@comment)
            return render json: {success: true}
        else
            # redirect_to request.referrer, alert: "Cannot create comment"
            return render json: {success: false}
        end
    end

    private

    def render_comment(comment)
        self.render_to_string partial: 'orders/comment', locals: {comment: comment}
    end

    def comments_params
        params.require(:comment).permit(:content, :order_id, :attachment_file)
    end

    def is_valid_order
        redirect_to dashboard_path, alert: "Invalid order" unless Order.find(comments_params[:order_id]).present?
    end
end