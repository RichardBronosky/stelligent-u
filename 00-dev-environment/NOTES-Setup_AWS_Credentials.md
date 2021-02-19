
## Lab 0.1.1: AWS Access Keys

- Setup AWS Credentials

### Assets

- [awstool](../awstool)

### Commands

```
src=~/.aws/bruno.bronosky.labs_accessKeys.csv
dest=~/.aws/credentials
rm "$dest"
../awstool import_access_key_csv "$src"
aws sts get-caller-identity
```

### Transcript

```
$ src=~/.aws/bruno.bronosky.labs_accessKeys.csv
$ dest=~/.aws/credentials
$ rm "$dest"
$ aws sts get-caller-identity
Unable to locate credentials. You can configure credentials by running "aws
configure".

$ ../awstool import_access_key_csv "$src"
Successfully imported 1 profile(s)

$ aws sts get-caller-identity
{
    "UserId": "AIDAUXAYGAAR7RIAHCQJS",
    "Account": "324320755747",
    "Arn": "arn:aws:iam::324320755747:user/bruno.bronosky.labs"
}
```
