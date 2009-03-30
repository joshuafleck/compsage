class AddResponseTypes < ActiveRecord::Migration
  def self.up
    add_column :responses, 'type', :string, :limit => 30
    rename_column :questions, 'question_type', 'response_type'
    Question.all do |question|
      question.response_type = case question.response_type
                               when 'text_field'
                                 'ShortTextualResponse'
                               when 'text_area'
                                 'LongTextualResponse'
                               when 'numerical_field'
                                 'NumericalResponse'
                               when 'radio'
                                 'MultipleChoiceResponse'
                               when 'checkbox'
                                 'MultipleChoiceResponse'
                               when 'text'
                                 nil
                               when 'wage_range'
                                 'WageResponse'
                               when 'base_wage'
                                 'BaseWageResponse'
                               end
      question.save
    end
  end

  def self.down
    remove_column :responses, 'type'
    rename_column :questions, 'response_type', 'question_type'
    Question.all do |question|
      question.question_type = case question.question_type
                               when 'ShortTextualResponse'
                                 'text_field'
                               when 'LongTextualResponse'
                                 'text_area'
                               when 'NumericalResponse'
                                 'numerical_field'
                               when 'MultipleChoiceResponse'
                                 'radio'
                               when 'MultipleChoiceResponse'
                                 'checkbox'
                               when nil
                                 'text'
                               when 'WageResponse'
                                 'wage_range'
                               when 'BaseWageResponse'
                                 'base_wage'
                               end
      question.save
    end

  end
end
