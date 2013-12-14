(See http://adit.io/posts/2013-08-16-five-useful-git-tips.html)

1. Compile and install the `trimWhitespace` tool:

        make install

2. Make a `.gitattributes` file in your project root with these contents:

        *.rb filter=trimWhitespace

This says every ruby file will go through the trimWhitespace filter. 
You could apply it to all files like this:

        * filter=trimWhitespace

3. Define the filter:

        $ git config filter.trimWhitespace.clean trim_whitespace

Every filter can be run at two different hooks: right after you pull, or right before you push. 
The *smudge* filter is for right after pulling and the *clean* filter is for right before pushing. 

The above command creates a new filter called `trimWhitespace` for the *clean* action - it runs
all code through the `trim_whitespace` utility before pushing.
