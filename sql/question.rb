require_relative 'questions_database.rb'


class Question
  attr_accessor :title, :body, :user_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |data| Question.new(data) }
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      questions
    WHERE
      id = ?
    SQL

    Question.new(question.first)
  end

  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
    SELECT
      *
    FROM
      questions
    WHERE
      user_id = ?
    SQL
    questions.map { |question_hsh| Question.find_by_id(question_hsh['id'])}

  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options ['body']
    @user_id = options['user_id']
  end

  def create
    raise "#{self} exists" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
    INSERT INTO
      questions (title, body, user_id)
    VALUES
      (? , ? , ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def author
    User.find_by_id(@user_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  

end
