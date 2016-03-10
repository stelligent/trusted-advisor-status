module HashUtil

  def self.stringify_keys(hash)
    new_hash = {}
    hash.each do |k,v|
      if v.is_a? Hash
        new_hash[k.to_s] = stringify_keys(v)
      elsif v.is_a? Array
        new_array = v.map do |element|
          if element.is_a? Hash
            stringify_keys(element)
          else
            element
          end
        end
        new_hash[k.to_s] = new_array
      else
        new_hash[k.to_s] = v
      end
    end
    new_hash
  end
end