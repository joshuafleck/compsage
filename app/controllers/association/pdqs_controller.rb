class Association::PdqsController < Association::AssociationController
  # Controls adding, editing and deleting predefined questions for an association owner.
    before_filter :association_owner_login_required

    def new
      @predefined_question = PredefinedQuestion.new
      @question = Question.new
    end

    def create
      @question = Question.new(params[:question])
      @predefined_question = current_association_by_owner.predefined_questions.new(params[:predefined_question])

      # This will add errors to the Active record object because we derive the question object from params.
      @predefined_question.valid?

      # Check if the question is valid and the PDQ saves
      if @question.valid? then
        @predefined_question.question = @question
        if @predefined_question.save then
          redirect_to association_settings_path
          return
        end
      end

      # Re-render new template if question isn't valid
      render :action => 'new'
    end

    def edit
      @predefined_question = current_association_by_owner.predefined_questions.find(params[:id])
      @question = @predefined_question.question
    end

    def update
      @question = Question.new(params[:question])
      @predefined_question = current_association_by_owner.predefined_questions.find(params[:id])

      # gather PDQ errors
      @predefined_question.attributes = params[:predefined_question]
      @predefined_question.valid?

      #check if the question is valid and the PDQ saves
      if @question.valid? then
        @predefined_question.question = @question
        if @predefined_question.save then
          redirect_to association_settings_path
          return
        end
      end

      # Re-render edit template if question isn't valid
      render :action => 'edit'
    end

    def destroy
       @question = current_association_by_owner.predefined_questions.find(params[:id])

       if @question.destroy then
         flash[:message] = "This question has been deleted."
         redirect_to association_settings_path
       end
     end
  end
