class MessagesController < ApplicationController
  before_action :load_user, only: [:new, :create]

  def index
    @messages = load_messages.includes(:from, :to)
  end

  def new
    @message = Message.new
  end

  def create
    @message = current_user.sent_messages.build(message_params)

    respond_to do |format|
      if @message.save
        # Ideally move this to background
        UserMailer.new_message(current_user.id, message_params[:to_id]).deliver
        format.html { redirect_to messages_path, notice: 'Message sucessfully sent!' }
      else
        format.html { render :new }
      end
    end
  end

  private
    def set_message
      @message = Message.find(params[:id])
    end

    def message_params
      params.require(:message).permit(:to_id, :content)
    end

    def load_user
      to_id = params[:to_id] || message_params[:to_id]
      @user = User.find_by(id: to_id)

      return redirect_to messages_path unless @user.present?
    end

    def load_messages
      @sent = params[:sent]
      if @sent
        current_user.sent_messages
      else
        current_user.received_messages
      end
    end
end
