# Topic 0: Development Environment

<!-- Inline answers expected where ✏️ is found -->
<!-- TOC -->

- [Topic 0: Development Environment](#topic-0-development-environment)
  - [Conventions](#conventions)
  - [Lesson 0.1: Setting up your development environment](#lesson-01-setting-up-your-development-environment)
    - [Principle 0.1](#principle-01)
    - [Practice 0.1](#practice-01)
      - [Lab 0.1.1: AWS Access Keys](#lab-011-aws-access-keys)
        - [Option 1: Getting Credentials via STS command](#option-1-getting-credentials-via-sts-command)
          - [Exercise 0.1.1: MFA Script](#exercise-011-mfa-script)
          - [Question 0.1.1: 1](#question-011-1)
          - [Question 0.1.1: 2](#question-011-2)
        - [Option 2: Using AWS Vault to automatically handle your temporary tokens](#option-2-using-aws-vault-to-automatically-handle-your-temporary-tokens)
      - [Lab 0.1.2: GitHub](#lab-012-github)
      - [Lab 0.1.3: Cloud9 Environment](#lab-013-cloud9-environment)
      - [Lab 0.1.4: Clone Repository](#lab-014-clone-repository)
    - [Retrospective 0.1](#retrospective-01)
      - [Question: Environments](#question-environments)
      - [Task](#task)

<!-- /TOC -->

## Conventions

- Do NOT store AWS credentials in code repositories.
  - [Managing access keys](https://docs.aws.amazon.com/general/latest/gr/aws-access-keys-best-practices.html)
  - [Configuration and credentials files](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html)

- DO use the Cloud9 environment for all training work unless otherwise specified.
- DO use the [AWS documentation and user guides](https://aws.amazon.com/documentation/).

## Lesson 0.1: Setting up your development environment

### Principle 0.1

*A reliable, repeatable process to create your development environment
leads to a solution others can contribute to.*

The following labs will prepare you to work through the Stelligent
new hire training over the next 8 weeks. During the training you
will be using AWS access keys for programmatic access to an AWS account,
GitHub code repositories, and AWS Cloud9 for your development environment.

### Practice 0.1

#### Lab 0.1.1: AWS Access Keys

Add your AWS access key and secret key to your laptop. You
will need to [install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
and then run some simple commands to confirm access using your keys:

- [list-buckets](https://docs.aws.amazon.com/cli/latest/reference/s3api/list-buckets.html)
- [describe-instances](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html)

Remember that the combination of an access key and a secret key are
the same as user credentials and should not be given out or stored
in a public location like a GitHub repository, nor should they be
transmitted in an insecure manner like unencrypted email.
_Never_ commit credentials to a git repo.

- [Enable MFA](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html)
  for your AWS account. With MFA enabled you will need to generate temporary
  credentials using your MFA device and STS. You can do this in a few
  ways. The first way would be to request the token from STS via the CLI.

##### Option 1: Getting Credentials via STS command

```sh
aws sts get-session-token \
    --serial-number arn:aws:iam::324320755747:mfa/USERNAME \
    --token-code 123456` \
/
```

This will return json containing the temporarily credentials.

```sh
"Credentials": {
    "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
    "SessionToken": "AQoDYXdzEJr...<remainder of security token>",
    "Expiration": "2018-10-11T10:09:50Z",
    "AccessKeyId": "ASIAIOSFODNN7EXAMPLE",
  }
}
```

Using these temporary credentials you will need to edit your `.aws/credentials`
file and change the security configuration for the profile to be used.

```sh
[temp]
output = json
region = us-east-1
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
aws_session_token = AQoDYXdzEJr...<remainder of security token>
```

Now set AWS_PROFILE to temp in your env, or set the --profile flag to temp when
running awscli. You should be able to access any of the resources you're
authorized to in the labs account. These tokens will last approximately
12 hours before needing to be reset using the process above.

###### Exercise 0.1.1: MFA Script

1. Create a script to automate the gathering and assigning of the temporary
  AWS MFA credentials from Option 1.
1. Try to reduce the amount of manual input as much as possible.

> - I created [this tool](../git-mkb) to aid in completing this course. See
> [these notes](NOTES-Setup_git_helpers.md#commands)
> - I added `import_access_key_csv` [this tool](../awstool) to address the
> loading credentials from CSV. See [these
> notes](NOTES-Setup_AWS_Credentials.md#commands)
> - I added `export_session_token` [this tool](../awstool) to address the use
> of session tokens. See [these notes](NOTES-MFA_Script.md#commands)

###### Question 0.1.1: 1

What method did you use to store the aws credentials?

> To store `session_token` or `assumed_role` credentials, I prefer to use the
> `AWS_`... [exported] ENV vars. I think those kinds of secrets should be kept
> in memory rather than written to disk.

What are some other options?

###### Question 0.1.1: 2

Which AWS environment variable cannot be set in order to run the
`aws sts get-session-token` command?

> It would seem the answer is `AWS_ACCESS_KEY_ID`, based on...
> ```txt
> $ ./awstool _test_get_session_token_with_env_vars
> Got fresh credentials using MFA OTP.
> Waiting 16 seconds for new OTP.
> 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
> Removing: AWS_ACCESS_KEY_ID, Leaving: AWS_EXPIRATION AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
> { "AccessKeyId": "...QWVFP533" }
> ---- 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0 ----
> Removing: AWS_EXPIRATION, Leaving: AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
>
> An error occurred (AccessDenied) when calling the GetSessionToken operation:
> Cannot call GetSessionToken with session credentials
> ---- 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0 ----
> Removing: AWS_SECRET_ACCESS_KEY, Leaving: AWS_ACCESS_KEY_ID AWS_EXPIRATION AWS_SESSION_TOKEN
>
> Partial credentials found in env, missing: AWS_SECRET_ACCESS_KEY
> ---- 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0 ----
> Removing: AWS_SESSION_TOKEN, Leaving: AWS_ACCESS_KEY_ID AWS_EXPIRATION AWS_SECRET_ACCESS_KEY
>
> An error occurred (InvalidClientTokenId) when calling the GetSessionToken operation:
> The security token included in the request is invalid.
> ----  ----
> ```

##### Option 2: Using AWS Vault to automatically handle your temporary tokens

If you would rather not have to manually get STS tokens and add them to your
credentials file you can use [aws-vault](https://github.com/99designs/aws-vault).

Configure the profile that you would like to use using this command:
`aws-vault add MY_PROFILE`

If you accidentally setup aws-vault with a password that you forgot,
you can remove its database (`rm -rf Library/Keychains/aws-vault.keychain-db`)
and start over.

To use aws-vault for temporary credential management is simple. You need to add
the arn of your mfa token to your profiles config in `~/.aws/config` like so:

```sh
[profile MY_PROFILE]
output = json
region = us-east-1
mfa_serial = arn:aws:iam::324320755747:mfa/USERNAME
```

Now you can execute any command using aws-vault. Example:
`aws-vault exec MY_PROFILE -- aws s3 ls`

You want to set an alias in your .bashrc or .zshrc to something like this:
`alias aws-myprofile="aws-vault exec MY_PROFILE -- aws"`

#### Lab 0.1.2: GitHub

1. Create a new repository from the [Stelligent-U repository
   template](https://github.com/stelligent/stelligent-u/generate)
1. Select the owner of the repository
1. Name the new private repository
1. Generate ssh keys and test access. Use [this GitHub
   guide](https://help.github.com/articles/connecting-to-github-with-ssh/) to
   get access and clone the private repo to your laptop.

#### Lab 0.1.3: Cloud9 Environment

AWS Cloud 9 is a resource to quickly re-create a stock development
environment accessible from almost anywhere in a browser. You can use
the Cloud9 environment to work on the remainder of the Stelligent-U
labs, but it is not required.

Create a new Cloud 9 environment in the region of your preference
(ie: `us-east-1`) in the AWS account using the [AWS user
guide](https://docs.aws.amazon.com/cloud9/latest/user-guide/welcome.html).
Be sure to note the different options when setting up the environment,
but use the default options for this lab. In Cloud9, run the same AWS
CLI commands as you did in [lab 0.1.1](#lab-011-aws-access-keys):

- `list-buckets`
- `describe-instances`

#### Lab 0.1.4: Clone Repository

Work with your GitHub repo in your Cloud9 development environment. Start
at [step 3 of this user guide](https://docs.aws.amazon.com/cloud9/latest/user-guide/sample-github.html#sample-github-install-git)
to configure the Cloud9 instance to work with GitHub.

1. Install git in Cloud9.

1. Clone the repository to your Cloud9 environment. To gain
   access to the repository try using either
   [token authentication](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)
   or an [SSH key](https://help.github.com/articles/connecting-to-github-with-ssh/).

### Retrospective 0.1

#### Question: Environments

Running the two commands in [lab 0.1.1](#lab-011-aws-access-keys) and
[lab 0.1.3](#lab-013-cloud9-environment) should have shown the same
results.

What does this tell you about the access the keys give you on your laptop and
the access you have in the Cloud9 environment?

> The access is effectively the same. It seems that
> /home/ec2-user/.aws/credentials is getting updated every ~8 minutes.

What other methods are there to provide this level of access without using keys?

> The EC2 instance could have been started with a ROLE that had the same
> permissions as the user launching it. But then you'd have to have a process
> that kept the ROLE in sync with permissions changes on the USER and any GROUPS
> they are in

#### Task

Configure Cloud9 to work with the programming language you will be using
to complete the training work. In your Cloud9 Editor, perform the following:

- Please choose either Ruby, Python, Go or NodeJS
- Create a new branch off master
- In the 00-dev-environment directory, develop a small "hello world!"
  application in that language
- Add the files to your new branch, commit them, and push the branch up to
  your forked repository
- Create a pull request from your branch to the master branch within your forked
  repository and merge after reviewing
