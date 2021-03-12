require './healthreport.rb'
require './ledctrl.rb'
require 'win32/service'
require 'win32/daemon'

include Win32

SERVICE_NAME = 'SrvQuickMon'
SERVICE_DISPLAY_NAME = "Svinopterix's Windows Health Reporter"
SERIAL_PORT = 'COM3'
SERVICE_DELAY = 10.0
RUBY_PATH = 'C:\\Ruby27-x64\\bin\\ruby.exe'


class HealthMonSvc < Daemon
    def service_init
        sleep 10

        @ledctl = LedController.new(SERIAL_PORT, 9600)
        @ledctl.openport
        @ledctl.setledmodes(0, 0, 0)
    end

    def service_main
        begin
            while state == RUNNING
                @ledctl.setledmode(1, 1)
                sleep SERVICE_DELAY
            end
                @ledctl.closeport
        rescue StandardError, Interrupt => e
            @ledctl.closeport
        end
    end

    def service_stop
        @ledctl.closeport

    rescue
        # File.open("C:\\test.log", "a"){ |f| f.puts "Service is running #{Time.now}" } 
    end
end

# parse command line parameters
param = ARGV[0]
case param

when 'register'
    svc = Service.create(
        :service_name       => SERVICE_NAME,
        :host               => 'localhost',
        :service_type       => Service::WIN32_OWN_PROCESS,
        :description        => 'Silly health monitor, notificator and LED controller',
        :start_type         => Service::AUTO_START,
        :error_control      => Service::ERROR_NORMAL,
        :binary_path_name   => RUBY_PATH + ' ' + File.expand_path($0).gsub('/', '\\') + ' service',
        :dependencies       => ['W32Time'],
        :service_start_name => 'SVDESK\healthmon',
        :password           => 'aSscoming15',
        :display_name       => SERVICE_DISPLAY_NAME,
      )

    Service.start SERVICE_NAME

    puts 'Successfully registered service ' + SERVICE_NAME + '(#{SERVICE_DISPLAY_NAME})'

when 'delete'
    if Service.status(SERVICE_NAME).current_state == "running"
        Service.stop(SERVICE_NAME)
    end
    
    Service.delete(SERVICE_NAME)
    
    puts "Removed Service - " + SERVICE_DISPLAY_NAME

when 'service'
    HealthMonSvc.mainloop

else
    if ENV["HOMEDRIVE"]!=nil
        puts "Usage: healthmon.rb [option]"
        puts "\nOptions:"
        puts "register - Install service"
        puts "delete - Stop and uninstall service"
    end
end