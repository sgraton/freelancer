class ConversationsController < ApplicationController
    before_action :get_conversations

    def list
    end

    def show
        @user = User.find(params[:id])
        
        @conversation = Conversation.where("(sender_id = ? and receiver_id = ?) or (sender_id = ? and receiver_id = ?)",
                                            current_user.id,
                                            params[:id],
                                            params[:id],
                                            current_user.id).first
        
        if !@conversation.present?
            redirect_to conversations_path, alert: "Conversation non valide"
        else
            @messages = Message.where(conversation_id: @conversation.id)
        end
    end

    private

    def get_conversations
        @conversations = Conversation
                            .where("sender_id = ? or receiver_id = ?", current_user.id, current_user.id)
                            .order(updated_at: :desc)
    end
end