require 'rubyserial'

INITIAL_DELAY = 3.0
READ_DELAY = 0.1

class LedController
    def initialize(port, baudrate)
      @port, @baudrate = port, baudrate
      @serial = nil
    end

    def openport
        @serial = Serial.new(@port, @baudrate)
        sleep INITIAL_DELAY
    end

    def closeport
        @serial.close()
    end

    def setledmode(led, mode)
        raise "Incorrect LED ID" if ((led > 2) || (led < 0)) 
        raise "Incorrect mode" if ((mode > 3) || (mode < 0)) 

        s = "#{led.to_s}#{mode.to_s}\r"

        @serial.write(s)

        sleep READ_DELAY

        return @serial.read(3)
    end

    def setledmodes(mode0, mode1, mode2)
        raise "Incorrect modes" if ((mode0 > 3) || (mode1 > 3) || (mode2 > 3) || (mode0 < 0) || (mode1 < 0) || (mode2 < 0))

        s = "#{mode0.to_s}#{mode1.to_s}#{mode2.to_s}\r"

        @serial.write(s)

        sleep READ_DELAY

        return @serial.read(3)
    end
end

# ledctl = LedController.new('COM3', 9600)