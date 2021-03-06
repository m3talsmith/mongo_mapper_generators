require File.join(File.dirname(__FILE__), "..", "support", "generator_helper")

class MongoModelGenerator < Rails::Generator::NamedBase
  attr_accessor :belongs, :many, :timestamps, :userstamps
  
  default_options :skip_factories  => false, :skip_timestamps => false
  
  def initialize(runtime_args, runtime_options = {})
    super
    
    parsed_attributes = []
    
    @args.each do |arg|
      if arg.include? ':'
        parsed_attributes << MongoAttribute.new(*arg.split(":"))
      end
    end
    
    @attributes = parsed_attributes.reject { |each| %w(many belongs_to).include? each.name }
    @many = parsed_attributes.select { |each| each.name == 'many' }
    @belongs = parsed_attributes.select { |each| each.name == 'belongs_to' }
    @timestamps = !options[:skip_timestamps]
    @userstamps = !options[:skip_userstamps]
  end
  
  def manifest
    record do |m|
      m.directory 'app/models'
      m.template 'mongo_model.rb', "app/models/#{singular_name}.rb"
      
      m.directory 'test/unit'
      m.template 'unit_test.rb',  File.join('test/unit', class_path, "#{singular_name}_test.rb")

      unless options[:skip_factories]
        m.directory 'test/factories'
        m.template 'factory.rb', File.join('test/factories', "#{plural_name}.rb")
      end
    end
  end
  
  def factory_line(attribute, file_name)
    "#{file_name}.#{attribute.name} #{attribute.default_for_factory}"
  end  

  protected

    def banner
      "Usage: #{$0} #{spec.name} ModelName [field:type, field:type] --skip-factories --skip-timestamps --skip-userstamps"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-factories", "Don't generate a factory for this model") { |v| 
        options[:skip_factories] = v 
      }
      opt.on("--skip-timestamps", "Don't add timestamps to this model") { |v| 
        options[:skip_timestamps] = v 
      }
      opt.on("--skip-userstamps", "Don't add userstamps to this model") { |v| 
        options[:skip_userstamps] = v 
      }
    end
end