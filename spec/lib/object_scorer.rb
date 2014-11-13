require 'spec_helper'
require 'object_similarity'

describe ObjectSimilarity::ObjectScorer do
  let(:object_class) { Struct.new(:name, :age) }
  let(:object1) do
    object_class.new('Jim', 15)
  end

  let(:field_scorers) { {} }

  let(:field_weights) { {} }

  let(:scorer) do
    ObjectSimilarity::ObjectScorer.new(:euclidean_distance, object1, field_scorers, field_weights)
  end

  describe '#score' do
    subject { scorer.score(object_class.new(name, age)) }

    context 'scoring name exactly' do
      let(:field_scorers) { {name: :exact} }

      context 'perfect name match' do
        let(:name) { 'Jim' }

        context 'perfect age match' do
          let(:age) { 15 }
          it { should == 0 }
        end

        context 'imperfect age match' do
          let(:age) { 14 }
          it { should == 0 }
        end
      end

      context 'imperfect name match' do
        let(:name) { 'jim' }

        context 'perfect age match' do
          let(:age) { 15 }
          it { should == 1 }
        end

        context 'imperfect age match' do
          let(:age) { 14 }
          it { should == 1 }
        end
      end
    end

    context 'also age exactly' do
      let(:field_scorers) { {name: :exact, age: :exact} }

      context 'perfect name match' do
        let(:name) { 'Jim' }

        context 'perfect age match' do
          let(:age) { 15 }
          it { should == 0 }
        end

        context 'age off by one' do
          let(:age) { 14 }
          it { should == 1 }
        end

        context 'age off by two' do
          let(:age) { 13 }
          it { should == 1 }
        end

        context 'age off by two (other direction)' do
          let(:age) { 17 }
          it { should == 1 }
        end
      end

      context 'imperfect name match' do
        let(:name) { 'jim' }

        context 'perfect age match' do
          let(:age) { 15 }
          it { should == 1 }
        end

        context 'age off by one' do
          let(:age) { 14 }
          it { should == 2 }
        end

        context 'age off by two' do
          let(:age) { 13 }
          it { should == 2 }
        end

        context 'age off by two (other direction)' do
          let(:age) { 17 }
          it { should == 2 }
        end
      end
    end

    context 'scoring age by nearness' do
      let(:field_scorers) { {name: :exact, age: :nearness} }

      context 'perfect name match' do
        let(:name) { 'Jim' }

        context 'perfect age match' do
          let(:age) { 15 }
          it { should == 0 }
        end

        context 'age off by one' do
          let(:age) { 14 }
          it { should == 1 }
        end

        context 'age off by two' do
          let(:age) { 13 }
          it { should == 4 }
        end

        context 'age off by two (other direction)' do
          let(:age) { 17 }
          it { should == 4 }
        end
      end

      context 'imperfect name match' do
        let(:name) { 'jim' }

        context 'perfect age match' do
          let(:age) { 15 }
          it { should == 1 }
        end

        context 'age off by one' do
          let(:age) { 14 }
          it { should == 2 }
        end

        context 'age off by two' do
          let(:age) { 13 }
          it { should == 5 }
        end

        context 'age off by two (other direction)' do
          let(:age) { 17 }
          it { should == 5 }
        end

      end
    end
  end
end


