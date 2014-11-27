require "platform-api"

module Heroku
  class Application < Struct.new(:name, :api_key)
    def self.with(name:, api_key:)
      new(name, api_key)
    end

    def url
      "http://#{name}.herokuapp.com"
    end

    def destroy
      Rails.logger.info("Destroying Heroku Application: #{name}...")
      heroku_platform.app.delete(name)
    rescue Excon::Errors::NotFound
    rescue Excon::Errors::Forbidden
      false
    end

    def deploy_branch(tarball)
      Rails.logger.info("Building #{tarball} on #{name}...")
      build = heroku_platform.build.create(
        name,
        "source_blob" => { "url" => tarball, "version" => "preview" }
      )

      wait_build_completion(build)
    end

    def fork_into(application)
      heroku_clt("fork", application.name)
    end

    def run_command(command)
      heroku_clt("run", command)
    end

    private

    def heroku_platform
      @heroku_platform ||= PlatformAPI.connect_oauth(api_key)
    end

    def wait_build_completion(build, poll_interval: 5)
      loop do
        Rails.logger.info("Waiting for build completion on #{name}...")
        sleep poll_interval
        begin
          info = heroku_platform.build.info(name, build["id"])
          return if info["status"] != "pending"
        rescue Excon::Errors::ServiceUnavailable
        end
      end
    end

    def heroku_clt(command, arguments)
      command = "HEROKU_API_KEY=#{api_key} \
                 bundle exec heroku #{command} --app #{name} #{arguments}"

      Rails.logger.info("Running command on #{name}: #{command}")
      system(command)
    end
  end
end
