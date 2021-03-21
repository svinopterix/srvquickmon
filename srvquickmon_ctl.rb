require 'win32/service'
require 'rbconfig'

include Win32
include RbConfig

SERVICE_NAME = 'SrvQuickMon'
SERVICE_DISPLAY_NAME = "Svinopterix's Windows Health Reporter"
SERIAL_PORT = 'COM3'
SERVICE_DELAY = 10.0
RUBY_PATH = File.join(CONFIG['bindir'], CONFIG['ruby_install_name']).tr('/', '\\').freeze
LOG_FILE = 'C:\\Users\\svino\\tmp\\srvquickmon.log'
SERVICE_FILE = 'srvquickmon.rb'


param = ARGV[0]
case param

    when 'register'
        svc = Service.create(
         :service_name       => SERVICE_NAME,
         :display_name       => SERVICE_DISPLAY_NAME,
         :host               => 'localhost',
         :description        => 'Silly health monitor, notificator and LED controller',
         :binary_path_name   => RUBY_PATH + " \"" + File.dirname(File.expand_path($0)).tr('/', '\\') + "\\#{SERVICE_FILE}\""
        )
        puts "Successfully registered service #{SERVICE_NAME} (#{SERVICE_DISPLAY_NAME})"
    
    when 'start'
        Service.start SERVICE_NAME
        puts "Service #{SERVICE_NAME} started"

    when 'stop'
        Service.stop(SERVICE_NAME) if Service.status(SERVICE_NAME).current_state == "running"  
        puts "Service stopped"

    when 'delete'
        Service.stop(SERVICE_NAME) if Service.status(SERVICE_NAME).current_state == "running"  
        Service.delete(SERVICE_NAME)  
        puts "Removed Service - " + SERVICE_DISPLAY_NAME

    when 'test'
        puts File.dirname(File.expand_path($0)).tr('/', '\\')+"\\#{SERVICE_FILE}"

else
    unless ENV["HOMEDRIVE"] == nil
        puts "Usage: healthmon.rb [option]"
        puts "\nOptions:"
        puts "register - Install service"
        puts "start - Start service"
        puts "stop - Stop service"
        puts "delete - Stop and uninstall service"
    else

    end
end