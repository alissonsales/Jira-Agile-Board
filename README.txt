An Scrum board filled with jira issues retrieved from the Jira SOAP API

The issues are retrieved from a specific jira filter. I would like to use JQL but i'm doing this to use with Jira prior to version 4.

In order to make this work you need to certify that the Jira SOAP API is up and running and configure a Jira filter to retrieve open, reopened, in progress, resolved and closed issues from a project.

The statuses ids may vary according to your Jira configurations, to handle this you can change the Board constants (at the moment, this project is just a toy so, i'll not put those configurable data in a file or anything else)

