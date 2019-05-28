# frozen_string_literal: true

class SessionsController < ApplicationController
  def new; end

  def create
    # 👇ログイン失敗した場合でもnewのページに移動するだけだから同じインスタンスが破棄されていない。@userとしたら値が保持されたままになる。
    # 👇サインアップのページとかなら保持されてていいけどログインで保持しとかなくていいかな
    # 👇userはローカル変数だからcreateメソッドから抜けたら破棄される。それでよいのだきっと
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user&.authenticate(params[:session][:password])
      if @user.activated?
        log_in @user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        redirect_back_or @user
      else
        message  = 'Account not activated. '
        message += 'Check your email for the activation link.'
        flash[:warning] = message
        redirect_to root_url
      end
    else
      # エラーメッセージを作成する
      flash.now[:danger] = 'Invalid email/password combination' # 本当は正しくない
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
