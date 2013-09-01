module PubliSci
	module Parser

    def is_uri?(string)
      RDF::Resource(string).valid?
    end

    def sanitize(array)
      #remove spaces and other special characters
      array = Array(array)
      processed = []
      array.map{|entry|
        if entry.is_a? String
          if is_uri? entry
            processed << entry.gsub(/[\s]/,'_')
          else
            processed << entry.gsub(/[\s]/,'_')
          end
        else
          processed << entry
        end
      }
      processed
    end

    def sanitize_hash(h)
      mappings = {}
      h.keys.map{|k|
        if(k.is_a? String)
          mappings[k] = k.gsub(' ','_')
        end
      }

      h.keys.map{|k|
        h[mappings[k]] = h.delete(k) if mappings[k]
      }

      h
    end

		def load_string(string,repo=RDF::Repository.new)
			f = Tempfile.new('repo')
			f.write(string)
			f.close
			repo.load(f.path, :format => :ttl)
			f.unlink
			repo
		end

		def get_ary(query_results,method='to_s')
      query_results.map{|solution|
        solution.to_a.map{|entry|
          if entry.last.respond_to? method
	          entry.last.send(method)
	        else
	        	entry.last.to_s
	        end
        }
      }
    end

    def get_hashes(query_results,method=nil)
    	arr=[]
    	query_results.map{|solution|
    		h={}
    		solution.map{|element|
					if method && element[1].respond_to?(method)
					 	h[element[0]] = element[1].send(method)
					else
					 	h[element[0]] = element[1]
					end
    		}
    		arr << h
    	}
    	arr
    end

    def observation_hash(query_results,shorten_uris=false,method='to_s')
    	h={}
    	query_results.map{|sol|
    		(h[sol[:observation].to_s] ||= {})[sol[:property].to_s] = sol[:value].to_s
    	}

    	if shorten_uris
	    	newh= {}
	    	h.map{|k,v|
	    		newh[strip_uri(k)] ||= {}
	    		v.map{|kk,vv|
	    			newh[strip_uri(k)][strip_uri(kk)] = strip_uri(vv)
	    		}
	    	}
	    	newh
	    else
	    	h
	    end
    end

    def to_resource(obj, options={})
      if obj.is_a? String

        obj = "<#{obj}>" if is_uri? obj

        #TODO decide the right way to handle missing values, since RDF has no null
        #probably throw an error here since a missing resource is a bigger problem
        obj = "rdf:nil" if obj.empty?

        #TODO  remove special characters (faster) as well (eg '?')
        obj=  obj.gsub(' ','_')

      elsif obj == nil && options[:encode_nulls]
        'rdf:nil'
      elsif obj.is_a? Numeric
        #resources cannot be referred to purely by integer (?)
        "n"+obj.to_s
      else
        obj
      end
    end

    def to_literal(obj, options={})
      if obj.is_a? String
        # Depressing that there's no more elegant way to check if a string is
        # a number...
        if val = Integer(obj) rescue nil
          val
        elsif val = Float(obj) rescue nil
          val
        else
          '"'+obj+'"'
        end
      elsif obj == nil && options[:encode_nulls]
        #TODO decide the right way to handle missing values, since RDF has no null
        'rdf:nil'
      else
        obj
      end
    end

    def encode_value(obj,options={})
      if RDF::Resource(obj).valid?
        to_resource(obj,options)
      elsif obj && obj.is_a?(String) && (obj[0]=="<" && obj[-1] = ">")
        obj
      else
        to_literal(obj,options)
      end
    end

    def strip_uri(uri)
      uri = uri.to_s.dup
      uri[-1] = '' if uri[-1] == '>'
      uri.to_s.split('/').last.split('#').last
    end

    def strip_prefixes(string)
      string.to_s.split(':').last
    end

	end
end