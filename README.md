Ce dépôt à pour vocation de contenir tous les NaNos que j'écrirais dans des formats versionables sous Git, comme Asciidoc

Pour effectuer des rendus automatiques des documents asciidoc à chaque commit git, on peut utiliser le hook suivant:

```bash
# Tell the user what's going on.
echo "Rendering committed documentation..."

# Get unstaged changes out of the way, without touching the git staging area.
git stash save --quiet --keep-index --include-untracked

# Render the documentation in this context, keeping track of files we create
# and adding them to the git staging area.
CREATED_FILES=""
for index in `find -name "index.adoc"` ; do
    # Memorize the base name
    BASE_NAME=${index%.adoc}

    # HTML render
    HTML_NAME=${BASE_NAME}.html
    asciidoctor -v "${index}" &&
    git add --force ${HTML_NAME}
    CREATED_FILES="${HTML_NAME} ${CREATED_FILES}"

    # PDF render
    PDF_NAME=${BASE_NAME}.pdf
    asciidoctor-pdf -v "${index}"
    git add --force ${PDF_NAME}
    CREATED_FILES="${PDF_NAME} ${CREATED_FILES}"
done

# At this stage, our staging area is ready for the commit.
# Save it for future use and go back to the HEAD state.
git stash save --quiet --all

# Pop the working directory state from our initial backup.
# It is mostly what we want, only missing the files we just generated.
git stash pop --quiet stash@{1}

# Pop ONLY the staging area from our second backup, and delete said backup.
git reset --quiet stash .
git stash drop --quiet

# Update the working directory with the files we just generated, by grabbing
# them from the index
git checkout --quiet -- ${CREATED_FILES}

# Now our index and working directory states are just right.
# Leave a blank line to isolate docgen output from git commit output.
echo ""
```
