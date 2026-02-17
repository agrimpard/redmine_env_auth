class EnvAuthController < ApplicationController
  def info
    effective = remote_user
    variable_name = Setting.plugin_redmine_env_auth["env_variable_name"]
    original = request.env[variable_name]
    keys = request.env.keys.sort.select {|a|
      ["action_dispatch.", "action_controller.", "rack.", "puma."].none? {|b| a.start_with?(b)}
    }.join("\n  ")
    text = [
      "variable name: #{variable_name}",
      "original value: #{original.inspect}",
      "effective value: #{effective.inspect}"
    ].join("\n")

    text = "#{text}\navailable variables:\n  #{keys}"
    render :plain => text
  end

  def logout
    if Setting.plugin_redmine_env_auth["external_logout_target"] == ""
      redirect_to signout_path
    else 
      redirect_to Setting.plugin_redmine_env_auth["external_logout_target"]
    end
  end

  def callback
    if User.current.logged?
      back_url = params[:back_url]
      if back_url.present?
        # Accepter les URLs relatives ou les URLs absolues du même hôte
        if back_url.start_with?('/')
          redirect_to back_url
        else
          begin
            uri = URI.parse(back_url)
            # Vérifier que c'est le même hôte que la requête actuelle
            if uri.host == request.host
              relative_url = uri.path.presence || '/'
              relative_url += "?#{uri.query}" if uri.query.present?
              redirect_to relative_url
            else
              logger.warn "redmine_env_auth: back_url host mismatch (#{uri.host} vs #{request.host})"
              redirect_to home_path
            end
          rescue URI::InvalidURIError
            logger.warn "redmine_env_auth: invalid back_url: #{back_url}"
            redirect_to home_path
          end
        end
      else
        redirect_to home_path
      end
    else
      flash[:error] = l(:notice_account_invalid_credentials)
      redirect_to signin_path
    end
  end
end
