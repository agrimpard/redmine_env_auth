module RedmineEnvAuth
  class Hooks < Redmine::Hook::ViewListener
    # Hook pour afficher les boutons d'authentification externe sur la page de login
    render_on :view_account_login_bottom, :partial => 'hooks/redmine_env_auth/login_buttons'
  end
end
