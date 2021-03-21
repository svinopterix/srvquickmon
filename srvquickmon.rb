RUN_DIR = File.dirname(File.expand_path($0)).tr('/', '\\').freeze

require "#{RUN_DIR}\\healthreport.rb"
require "#{RUN_DIR}\\ledctrl.rb"
require 'win32/daemon'

include Win32

SERVICE_NAME = 'SrvQuickMon'
SERVICE_DISPLAY_NAME = "Svinopterix's Windows Health Reporter"
SERIAL_PORT = 'COM3'
SERVICE_DELAY = 10.0
RUBY_PATH = 'C:\\Ruby27-x64\\bin\\ruby.exe'
LOG_FILE = 'C:\\tmp\\srvquickmon.log'


class HealthMonSvc < Daemon

    def log(msg)
        File.open(LOG_FILE, 'a'){ |f| f.puts("#{Time.now.to_s} <> #{msg}") }
    end

    def service_init
        log('HealthMon initializing')
        @ledctl = LedController.new(SERIAL_PORT, 9600)
        @healthrep = WinHealthReporter.new
    end

    def service_main
        log('HealthMon started')

        while running?
            
            unless @ledctl.opened?
                log('Opening COM port')
                @ledctl.openport
            end

            if state == RUNNING
                # Service is running

                failure_detected = false
                
                # Control leds
                @ledctl.setledmode(1, 1) if @ledctl.opened? # heartbit led

                unless @healthrep.health_ok?
                    @ledctl.setledmode(0, 2)
                    log('Failure detected') unless failure_detected
                    failure_detected = true
                else
                    @ledctl.setledmode(0, 0)
                    log('Failure recovered') if failure_detected
                    failure_detected = false
                end
                
                sleep SERVICE_DELAY
            else
                # PAUSED or IDLE
                sleep SERVICE_DELAY
            end          
 
        end

    rescue
        log('Closing COM port')
        @ledctl.closeport
        log('HealthMon failed')

    ensure
        log('Closing COM port')
        @ledctl.closeport
        log('HealthMon stopped')
    end

    def service_stop
        log('Closing COM port')
        @ledctl.closeport
        log('HealthMon stopping')
    end

    def service_pause
        log('HealthMon paused')
    end

    def service_resume
        log('HealthMon resumed')
    end
end


HealthMonSvc.mainloop
