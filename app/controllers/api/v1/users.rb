module API
  module V1
    class Users < Grape::API
      include API::V1::Defaults

      before do
        authenticate_user!
      end

      helpers do
        def load_user id
          @user = User.find_by id: id
        end
      end
      resource :users do
        desc "Return all users"
        get "", root: :users do
          User.all
        end

        desc "Return a user"
        params do
          requires :id, type: String, desc: "ID of the user"
        end
        get ":id", root: "user" do
          load_user params[:id]
        end
      end

      resource :users do
        desc "Update user"
        params do
          optional :name, type: String, desc: "Name of the user"
          optional :address, type: String, desc: "Adress of the user"
          optional :phone, type: String, desc: "Phone of the user"
          optional :email, type: String, desc: "Email of the user"
        end
        patch "/:id", root: "user" do
          load_user params[:id]
          if @user.update params
            present user: "#{@user} updated"
          else
            error!("Failed to update user", 401)
          end
        end

        desc "Delete user"
        delete "/:id", root: "user" do
          load_user params[:id]
          if @user&.destroy
            present user: "#{@user} deleted"
          else
            error!("Failed to delete user", 401)
          end
        end
      end
    end
  end
end
