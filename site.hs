--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll


--------------------------------------------------------------------------------
main :: IO ()
main = hakyllWith config $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.rst", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*/*/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts1 <- recentFirst =<< loadAll "posts/*"
            posts2 <- recentFirst =<< loadAll "posts/*/*/*"
            let posts = posts2 ++ posts1
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts1 <- recentFirst =<< loadAll "posts/*"
            posts2 <- recentFirst =<< loadAll "posts/*/*/*"
            let posts = posts2 ++ posts1
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

    create ["atom.xml"] $ do
      route   idRoute
      compile $ do
        let feedCtx =
              postCtx                 `mappend`
              bodyField "description"
        posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots "posts/*/*/*" "content"
        renderAtom myFeedConfiguration feedCtx posts

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

myFeedConfiguration = FeedConfiguration
  { feedTitle = "こうののブログ"
  , feedDescription = "こうののブログです"
  , feedAuthorName = "takoeight0821"
  , feedAuthorEmail = "takohati0821@gmail.com"
  , feedRoot = "https://takoeight0821.github.io"
  }

config :: Configuration
config = defaultConfiguration
  { deployCommand = "git checkout source" `mappend`
                    "&& stack exec blog rebuild" `mappend`
                    "&& git checkout master" `mappend`
                    "&& rsync -a --filter='P _site/'" `mappend`
                    " --filter='P _cache/' --filter='P .git/'" `mappend`
                    " --filter='P .stack-work' --filter='P .gitignore'" `mappend`
                    " --delete-excluded _site/ ." `mappend`
                    "&& cp -a _site/. ." `mappend`
                    "&& git add -A" `mappend`
                    "&& git commit -m 'Publish'" `mappend`
                    "&& git push origin master:master" `mappend`
                    "&& git checkout source"
  }
