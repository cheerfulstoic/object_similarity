require 'matrix'

module ObjectSimilarity
  class SkipException < Exception
  end

  class FieldScorer
    attr_reader :field, :weight

    def initialize(field, object, weight, options = {})
      @field = field
      @object = object
      @weight = weight || 1
      @options = options
    end

    def weighted_distance(other_object)
      distance(other_object) * @weight
    end

    def value
      @value ||= (@options[:value] || get_value(@object)).tap do |v|
        raise SkipException if skip_value?(v)
      end
    end

    def get_value(object)
      object.send(@field).tap do |v|
        raise SkipException if skip_value?(v)
      end
    end


    def skip_value?(value)
      false
    end
  end

  class ExactFieldScorer < FieldScorer
    def distance(other_object)
      (value == get_value(other_object)) ? 0 : 1
    end
  end

  class NearnessFieldScorer < FieldScorer
    def skip_value?(value)
      value.nil?
    end

    def distance(other_object)
      (value - get_value(other_object)).abs
    end
  end

  class InsensitiveLevenshteinNearnessFieldScorer < NearnessFieldScorer
    def distance(other_object)
      Text::Levenshtein.distance(value.downcase, get_value(other_object).downcase)
    end
  end

  class ObjectScorer
    def initialize(type, object, field_scorers, field_weight, field_options = {})
      @type = type
      raise ArgumentError, "Invalid scoring type: #{@type.inspect}" if not respond_to?("#{@type}_score")
      @object = object

      @field_scorers = field_scorers.map do |field, scorer_definition|
        field_scorer_class(scorer_definition).new(field, object, field_weight[field], field_options[field] || {})
      end
    end

    def score(other_object)
      send("#{@type}_score", other_object)
    end

    def euclidean_distance_score(other_object)
      @field_scorers.inject(0) do |sum, scorer|
        sum += begin
          scorer.weighted_distance(other_object) ** 2
        rescue SkipException
          0 # Is this right?
        end
      end
    end

    def normalized_euclidean_distance_score(other_object)
      euclidean_distance_score(other_object) / Math.sqrt(@field_scorers.size)
    end

    def print_distances_report(other_object)
      @field_scorers.each do |scorer|
        print "#{scorer.field}: "
        begin
          puts "#{scorer.distance(other_object)} * #{scorer.weight}"
        rescue SkipException
          puts "SKIPPED"
        end
      end
    end

    private



    def field_scorer_class(scorer_definition)
      if scorer_definition.is_a?(FieldScorer)
        scorer_definition
      else
        partial_class_name = scorer_definition.to_s.capitalize.gsub(/_[a-z]/i) do |match|
          match[1].upcase
        end

        Kernel.const_get("::ObjectSimilarity::#{partial_class_name}FieldScorer")
      end
    end
  end

end

