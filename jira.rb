require "rubygems"
require "sinatra"
require "haml"
require "jira4r"

set :haml, {:format => :html5 }

class MyJiraService
  attr_reader :address
  def initialize(params)
    @address = params[:url]
    @filter_id = params[:filter_id]
    
    @jira = Jira4R::JiraTool.new(2, @address)
    @jira.login(params[:user], params[:password])
    
    @project = @jira.getProjectByKey(params[:project_key])
    @issue_types = @jira.getIssueTypes()
    @subtask_issue_types = @jira.getSubTaskIssueTypes()
    @statuses = @jira.getStatuses()
  end
  
  def find_issue_type_by_id(id)
    @issue_types.find {|i| i.id == id}
  end
  
  def find_subtask_issue_type_by_id(id)
    @subtask_issue_types.find {|i| i.id == id}
  end
  
  def find_status_by_id(id)
    @statuses.find {|i| i.id == id}
  end
  
  def issues
    @jira.getIssuesFromFilter(@filter_id)
  end
end

class Board
  #open, reopened
  TODO_STATUSES = %w[1 4]
  #in progress
  IN_PROGRESS_STATUSES = %w[3]
  # resolved
  VERIFY_STATUSES = %w[5]
  # closed
  DONE_STATUSES = %w[6]

  attr_reader :todo, :in_progress, :verifying, :done
  
  def initialize(jira)
    @todo = []
    @in_progress = []
    @verifying = []
    @done = []
    @persons =[]
    @jira = jira
    
    issues = jira.issues
    populate(issues)
  end

  def get_person_class(person)
    if @persons.any? {|p| p == person}
      @persons.index(person)
    else
      @persons << person
      @persons.size - 1
    end
  end
  
  def render_issues(issues)
    content = ""
    issues.each do |i|
      content << %[
        <div class="issue type_#{i.type}">
          <span class="key"><a href="#{@jira.address}browse/#{i.key}">#{i.key}</a></span>
          <span class="summary">#{i.summary}</span><br />
          <span class="type type_#{i.type}">#{issue_type_description(i)}</span><br />
          <span class="assignee person_#{get_person_class(i.assignee)}">#{i.assignee}</span>
        </div>
      ]
    end
    content
  end
  
  def issue_type_description(issue)
    type = @jira.find_issue_type_by_id(issue.type) || @jira.find_subtask_issue_type_by_id(issue.type)
    if type then type.name else issue.type end
  end
  
  private
  
  def populate(issues)
    issues.each do |issue|
      if TODO_STATUSES.any? {|i| i == issue.status}
        @todo << issue
      elsif IN_PROGRESS_STATUSES.any? {|i| i == issue.status}
        @in_progress << issue
      elsif VERIFY_STATUSES.any? {|i| i == issue.status}
        @verifying << issue
      elsif DONE_STATUSES.any? {|i| i == issue.status}
        @done << issue
      end
    end
  end
end

get "/" do
  haml :index
end

post "/board" do
  jira = MyJiraService.new(params[:jira])
  board = Board.new(jira)
  haml :board, :locals => {:board => board}
end 