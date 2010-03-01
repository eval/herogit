def herogoo
  return @herogoo if defined? @herogoo
  @herogoo = {}

  `git config --get-regexp '^heroku\.'`.each_line do |line|
    key, value = line.chomp.split /\s+/
    @herogoo[key] = value
  end

  @herogoo
end

class Heroku::Command::Auth
  def get_credentials_with_git
    if File.directory? ".git"
      creds = herogoo.values_at "heroku.email", "heroku.password"
      @credentials = creds if 2 == creds.size
    end

    get_credentials_without_git
  end

  alias_method :get_credentials_without_git, :get_credentials
  alias_method :get_credentials, :get_credentials_with_git
end

class Heroku::Command::Base
  def extract_app_in_dir_with_git dir
    Dir.chdir dir do
      if /^\* (\S+)/ =~ `git branch`
        app = herogoo["heroku.app.#$1"]
        return app if app
      end
    end

    extract_app_in_dir_without_git dir
  end

  alias_method :extract_app_in_dir_without_git, :extract_app_in_dir
  alias_method :extract_app_in_dir, :extract_app_in_dir_with_git
end