# Lab 0.1.1: AWS Access Keys

- Exercise 0.1.1: MFA Script

## Assets

- [awstool](../awstool)

## Commands

```
source <(awstool export_session_token)
```

## Transcript

```
00-dev-environment $ env | grep '^AWS'

00-dev-environment $ aws s3 ls

An error occurred (AccessDenied) when calling the ListBuckets operation: Access
Denied

00-dev-environment $ source <(awstool export_session_token)
00-dev-environment $ aws s3 ls | tee >(head -n3) | tail
-n3
2020-04-26 15:38:27 324320755747--cft
2019-07-18 20:31:23 355a545f-262c-4f72-83d2-10b820d4c19d
2021-01-29 09:21:13 application-pipeline-artifactstorebucket-1xhs5j9qvndpl
2019-07-18 20:31:23 355a545f-262c-4f72-83d2-10b820d4c19d
2021-01-29 09:21:13 application-pipeline-artifactstorebucket-1xhs5j9qvndpl
2021-02-01 11:44:18 application-pipeline-artifactstorebucket-zbegzn37zm22

00-dev-environment $ env | grep '^AWS'
AWS_ACCESS_KEY_ID=ASIAUXA[...]
AWS_SECRET_ACCESS_KEY=Vqk[...]
AWS_SESSION_TOKEN=IQoJb3J[...]
AWS_EXPIRATION=2021-02-20T06:58:34+00:00
```
