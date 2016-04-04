#!/bin/bash

# Tell the user what's going on.
echo "Rendering committed documents..."

# Get gh-pages up to speed with the latest and greatest in master
PREVIOUS_BRANCH=`git rev-parse --abbrev-ref HEAD`
git checkout --quiet gh-pages
git merge --quiet -m "Updated to latest master changes" master

# Render the Asciidoc documents, keeping track of files we create
# and adding them to the git staging area.
CREATED_FILES=""
for index in `find -name "index.adoc"` ; do
    # Memorize the base name
    BASE_NAME=${index%.adoc}

    # HTML render
    HTML_NAME=${BASE_NAME}.html
    asciidoctor -d book "${index}"
    git add --force ${HTML_NAME}
    CREATED_FILES="${HTML_NAME} ${CREATED_FILES}"
done

# Commit the resulting rendered documents
git commit --quiet -m "Rendered new documents"

# Return to the previous branch
git checkout --quiet $PREVIOUS_BRANCH

# Now our index and working directory states are just right.
# Leave a blank line to isolate docgen output from git push output...
echo ""

# ...and push these changes out
git push origin $PREVIOUS_BRANCH gh-pages
