#
# Short report on PC health
#
require 'filesize'

# error codes for @health 
DISK_ERROR = 100
MEM_ERROR = 200
OTHER_ERROR = 300
HEALTH_OK = 0

# thresholds
FREESPACE_THRESHOLD = 90
FREERAM_THRESHOLD = 5

class HealthReporter

    def initialize
        @health = HEALTH_OK        
    end

    def health_ok?
        @health == HEALTH_OK
    end

    attr_accessor :health

    def header          # text report header
        outText = ["\n\n>>>>> Seconds report for #{ENV["COMPUTERNAME"]} (#{Time.now.inspect})"]

        return outText
    end

    def diskstatus
        return 'No realization'
    end

    def freespacestats
        return 'No realization'
    end

    def freememorystats
        return 'No realization'
    end

end

class WinHealthReporter < HealthReporter

    def diskstatus      # text disk status report
        outText = Array.new

        outText.push("\n\n============== HDD Status ==============")

        diskStatusCmd = `wmic diskdrive get caption,status /value`

        diskname = ''
        diskstatus = ''
        diskStatusCmd.split("\n").each do |s|
        
            p = s.match /(?<field>\w+)=(?<value>.+)/      
            next unless p
            case p[:field]
            when /Caption/
                diskname = p[:value].strip
                next
            when /Status/
                diskstatus = p[:value].strip

                # set health status
                @health = DISK_ERROR unless diskstatus =~ /OK/
            end
    
            outText.push("#{diskname.ljust(35)} #{diskstatus.ljust(10)}")
        end

        return outText
    end

    def freespacestats  # text free space report
        outText = Array.new

        outText.push("\n\n============== Free Space ==============")
        outText.push("#{"Disk".ljust(5)} #{"Name".ljust(15)} #{"Size".ljust(10)} #{"Free %".to_s.rjust(5)}")

        fsStats = `wmic logicaldisk get name,volumename,freespace,size`

        fsStats.split("\n").each do |s|
            p = s.match /(?<free>\d+)\s+(?<disk>\S+)\s+(?<size>\d+)\s+(?<volume>\S+)/
            if p
                totalSize = Filesize.from(p[:size]).pretty
                freePrc = ((p[:free].to_f / p[:size].to_f) * 100).round
                outText.push("#{p[:disk].ljust(5)} #{p[:volume].ljust(15)} #{totalSize.ljust(10)} #{freePrc.to_s.rjust(5)}")

                @health = DISK_ERROR if freePrc > FREESPACE_THRESHOLD
            end
        end

        return outText
    end

    def freememorystats
        outText = Array.new

        outText.push("\n\n=============== Free RAM ===============")
        memStats = `wmic ComputerSystem get TotalPhysicalMemory /value && wmic OS get FreePhysicalMemory /value`

        totalram = nil
        freeram = nil

        memStats.split("\n").each do |s|
            p = s.match /(?<field>\w+)=(?<value>.+)/  
            if p
                case p[:field]
                when /TotalPhysicalMemory/
                    totalram = p[:value].strip.to_f
                when /FreePhysicalMemory/
                    freeram = p[:value].strip.to_f
                end
            end
        end

        totalram = (totalram / (1024 ** 3))
        freeram = (freeram / (1024 ** 2))
        freeramprc = (freeram / totalram * 100).round

        @health = MEM_ERROR if freeramprc < FREERAM_THRESHOLD

        outText.push("#{"Total RAM".rjust(10)} GB #{"Free RAM".rjust(10)} GB #{"Free RAM %".rjust(10)}")
        outText.push("#{totalram.round.to_s.rjust(10)} GB #{freeram.round.to_s.rjust(10)} GB #{freeramprc.to_s.rjust(10)}%")
    end

end


# r = WinHealthReporter.new

# puts r.header
# puts r.diskstatus
# puts r.freespacestats
# puts r.freememorystats