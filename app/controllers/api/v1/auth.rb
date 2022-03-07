module API
  module V1
    class Auth < Grape::API
      include API::V1::Defaults
      helpers do
        def represent_user_with_token user
          present jwt_token: AuthToken.create(token:
                             Authentication.encode(user_id: user.id)).token
        end
      end
      resources :auth do
        desc "Sign in"
        params do
          requires :email
          requires :password
        end

        post "/sign_in" do
          user = User.find_by email: params[:email]
          if user.valid_password? params[:password]
            represent_user_with_token user
          else
            error!("Invalid email/password combination", 401)
          end
        end

        desc "Sign out"

        delete "/sign_out" do
          authenticate_user!
          token = AuthToken.find_by token: request.headers["Jwt-Token"]
          token&.destroy
          present message: "Logged out"
        end
      end
    end
  end
end
