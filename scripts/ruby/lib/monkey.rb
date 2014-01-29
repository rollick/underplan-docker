
module Docker
    class Container 
        def running?
            json["State"]["Running"]
        end

        def stopped?
            !json["State"]["Running"]
        end

        def name
            json["Name"].to_s
        end

        def titleize
            name.titleize
        end
    end
end

class Object
    # From : Rails
    def try(*a, &b)
        if a.empty? && block_given?
            yield self
        else
            public_send(*a, &b) if respond_to?(a.first)
        end
    end
end

class Hash
    # Mostly from : http://stackoverflow.com/a/5985554
    def camelize_keys
        result = {}
        self.map do |k, v|
            mapped_key = k.camelize
            result[mapped_key] = v.kind_of?(Hash) ? v.camelize_keys : v
            result[mapped_key] = v.collect{ |obj| obj.camelize_keys if obj.kind_of?(Hash)} if v.kind_of?(Array)
        end
        result
    end
end

class String
    def titleize
        self.split(/\s|-/).collect {|word| word.capitalize}.join(" ")
    end

    # From : http://english.rubyforge.org/rdoc/classes/English/Humanize.html#M000078
    def camelize(first_letter_in_uppercase = true)
        if self.match /^[A-Z|_]+$/i
            if first_letter_in_uppercase
                to_s.gsub(/\/(.?)/){ "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/){ $1.upcase }
            else
                lowercase_and_underscored = to_s
                lowercase_and_underscored[0,1] + lowercase_and_underscored.camelize[1..-1]
            end
        else
            return self
        end
    end
end