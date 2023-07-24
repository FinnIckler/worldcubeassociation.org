class Api::V10::UsersController < Api::V10::ApiController
  def me
    if current_user
      if stale?(current_user)
        render json: { user: current_user }
      end
    else
      render status: :unauthorized, json: { error: "Please log in" }
    end
  end

  def permissions
    if current_user
      if stale?(current_user)
        render json: {
          can_attend_competitions: {
            scope: current_user.cannot_register_for_competition_reasons.empty? ? "*" : [],
          },
          can_organize_competitions: {
            scope: current_user.can_create_competitions? ? "*" : [],
          },
          can_administer_competitions: {
            scope: current_user.can_admin_competitions? ? "*" : (current_user.delegated_competitions + current_user.organized_competitions).pluck("id"),
          },
        }
      end
    else
      render status: :unauthorized, json: { error: "Please log in" }
    end
  end
end
