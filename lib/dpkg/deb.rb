require "dpkg/deb/version"

module Dpkg
  module Deb
    # Your code goes here...
    class << self

      def fields(package_path, fieldnames = [])
        out = `dpkg-deb -f #{package_path} #{fieldnames.join(" ")}`

        # rules are:
        # fields are usually line-based and follow the general format of
        # <field name><colon><space><field value>, for example
        # Maintainer: Felix Gilcher <felix.gilcher@asquera.de>
        # The exception to the rule is the decription field that has the format
        # <field name><colon><space><short description><newline>
        # <description>
        # The description needs to be indented by a single space and empty lines
        # are replaced by a dot.

        fields = {}
        description = []

        out.each_line do |line|

          if match = /^(?<fieldname>[^:]+): (?<fieldvalue>.+)$/.match(line)
            fields[match['fieldname']] = match['fieldvalue']
          elsif match = /^ .+$/.match(line)
            description.push line
          else
            raise "unparseable line '#{line}' found"
          end

        end

        fields['Description'] << description.join("") unless fields['Description'].nil?

        fields
      end

      def contents(package_path)
        out = `dpkg-deb -c #{package_path}`
        contents = []

        out.each_line do |line|
          file = {}
          line = line.split(' ')

          file[:mode]  = line[0]
          file[:owner] = line[1]
          file[:bytes] = line[2]
          file[:date]  = line[3]
          file[:time]  = line[4]
          file[:name]  = line[5..-1]

          contents << file
        end
      end

    end
  end
end
