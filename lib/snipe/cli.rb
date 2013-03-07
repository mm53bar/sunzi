require 'open3'

module Snipe
  class Cli < Thor
    include Thor::Actions

    desc "deploy [user@host:port] [role] [environment] [--sudo]", "Deploy snipe project"
    method_options :sudo => false
    def deploy(target = nil, role = nil, environment = nil)
      do_deploy(target, role, environment, options.sudo?)
    end

    desc "compile", "Compile sunzi project"
    def compile(role = nil, environment = nil)
      do_compile(role, environment)
    end

    no_tasks do
      include Sunzi::Utility

      def self.source_root
        File.expand_path('../../',__FILE__)
      end

      def do_deploy(target, role, environment, force_sudo)
        sudo = 'sudo ' if force_sudo
        user, host, port = parse_target(target)
        endpoint = "#{user}@#{host}"

        # compile attributes and recipes
        do_compile(role, environment, user, host, port)

        # The host key might change when we instantiate a new VM, so
        # we remove (-R) the old host key from known_hosts.
        `ssh-keygen -R #{host} 2> /dev/null`

        remote_commands = <<-EOS
        rm -rf ~/snipe &&
        mkdir ~/snipe &&
        cd ~/snipe &&
        tar xz &&
        #{sudo}bash install.sh
        EOS

        remote_commands.strip! << ' && rm -rf ~/snipe' if @config['preferences'] and @config['preferences']['erase_remote_folder']

        local_commands = <<-EOS
        cd .snipe
        tar cz . | ssh -o 'StrictHostKeyChecking no' #{endpoint} -p #{port} '#{remote_commands}'
        EOS

        Open3.popen3(local_commands) do |stdin, stdout, stderr|
          stdin.close
          t = Thread.new do
            while (line = stderr.gets)
              print line.color(:red)
            end
          end
          while (line = stdout.gets)
            print line.color(:green)
          end
          t.join
        end
      end

      def do_compile(role, environment, user = nil, host = nil, port = nil)
        # Check if you're in the sunzi directory
        abort_with "You must be in the root of the application folder" unless File.exists?('Snipefile')
        # Check if role exists
        abort_with ".env.#{environment} doesn't exist!" if !File.exists?(".env.#{environment}")

        # Load sunzi.yml
        @config = YAML.load(File.read('Snipefile'))

        # Erase local 'compiled' folder
        erase_local_folder = @config['preferences'] && @config['preferences']['erase_local_folder']
        FileUtils.rm_rf ".snipe" if erase_local_folder

        # Retrieve remote recipes via HTTP
        cache_remote_recipes = @config['preferences'] && @config['preferences']['cache_remote_recipes']
        (@config[environment] || []).each do |key, value|
          next if cache_remote_recipes and File.exists?(".snipe/recipes/#{key}.sh")
          get value, ".snipe/recipes/#{key}.sh"
        end

        # Copy local files
        Dir['recipes/*'].each         {|file| copy_file File.expand_path(file), ".snipe/recipes/#{File.basename(file)}", :force => true }
        (@config['files'] || []).each {|file| copy_file File.expand_path(file), ".snipe/files/#{File.basename(file)}", :force => true }        

        # Create install.sh
        copy_file File.expand_path(".env.#{environment}"), ".snipe/install.sh", :force => true
        Dir['recipes/*'].each do |file|
          append_to_file '.snipe/install.sh', "source recipes/#{File.basename(file)}\n"
        end
       end
      
      def parse_target(target)
        target.match(/(.*@)?(.*?)(:.*)?$/)
        [ ($1 && $1.delete('@') || 'root'), $2, ($3 && $3.delete(':') || '22') ]
      end
    end
  end
  
  class Deployment
    attr_reader :user, :host, :port
    def initialize(args)
      @user, @host, @port = parse_target(args[:target])
    end
    
    def user
      @user ||= ENV['USER']
    end
    
    def host
      @host ||= ENV['HOST']
    end
    
    def port
      @port ||= ENV['PORT']
    end

    private
    
    def parse_target(target)
      target.match(/(.*@)?(.*?)(:.*)?$/)
      [ ($1 && $1.delete('@') || 'root'), $2, ($3 && $3.delete(':') || '22') ]
    end
end
