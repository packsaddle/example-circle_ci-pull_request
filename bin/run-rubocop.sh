#!/bin/bash
set -v
if [ "${CIRCLE_BRANCH}" != "master" ]; then
  # Circle-CI
  #

  gem install --no-document rubocop-select rubocop rubocop-checkstyle_formatter \
              checkstyle_filter-git saddler saddler-reporter-github \
              github_status_notifier

  github-status-notifier notify --state pending --context saddler/rubocop

  # CircleCI stop script ;(
  # git diff -z --name-only origin/master

  git diff -z --name-only origin/master \
   | xargs -0 rubocop-select

  git diff -z --name-only origin/master \
   | xargs -0 rubocop-select \
   | xargs rubocop \
       --require rubocop/formatter/checkstyle_formatter \
       --format RuboCop::Formatter::CheckstyleFormatter

  git diff -z --name-only origin/master \
   | xargs -0 rubocop-select \
   | xargs rubocop \
       --require rubocop/formatter/checkstyle_formatter \
       --format RuboCop::Formatter::CheckstyleFormatter \
   | checkstyle_filter-git diff origin/master

  git diff -z --name-only origin/master \
   | xargs -0 rubocop-select \
   | xargs rubocop \
       --require rubocop/formatter/checkstyle_formatter \
       --format RuboCop::Formatter::CheckstyleFormatter \
   | checkstyle_filter-git diff origin/master \
   | saddler report \
      --require saddler/reporter/github \
      --reporter Saddler::Reporter::Github::PullRequestComment

    github-status-notifier notify --exit-status $? --context saddler/rubocop
fi
exit 0
