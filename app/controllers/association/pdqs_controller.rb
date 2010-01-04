class Association::PdqsController < Association::AssociationController
    before_filter :association_owner_login_required

    def index
      @association = current_association_by_owner
    end

    def new
      @predefined_question = PredefinedQuestion.new
      @question = Question.new
    end

    def create
      @question = Question.new(params[:question])
      @predefined_question = current_association_by_owner.predefined_questions.new(params[:predefined_question])

      # gather PDQ errors
      @predefined_question.valid?

      #check if the question is valid and the PDQ saves
      if @question.valid? then
        @predefined_question.question = @question
        if @predefined_question.save then
          redirect_to predefined_questions_path
          return
        end
      end

      #this will only be reached something is not valid
      render :action => 'new'
    end

    def edit
      @predefined_question = current_association_by_owner.predefined_questions.find(params[:id])
      @question = @predefined_question.question
    end

    def update
      @predefined_question = current_association_by_owner.predefined_questions.find(params[:id])
      @question = Question.new(params[:question])

      # gather PDQ errors
      @predefined_question.valid?

      #check if the question is valid and the PDQ saves
      if @question.valid? then
        @predefined_question.question = @question
        if @predefined_question.save then
          redirect_to predefined_questions_path
          return
        end
      end

      #this will only be reached something is not valid
      render :action => 'edit'
    end

    def destroy
       @question = current_association_by_owner.predefined_questions.find(params[:id])

       # be sure to add confirm pop-up to view for this action link
       if @question.destroy then
         flash[:message] = "This question has been deleted."
         redirect_to predefined_questions_path
       end
     end
  end
