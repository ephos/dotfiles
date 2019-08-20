set -gx DOTNET_ROOT /opt/dotnet
set -gx MSBuildSDKsPath $DOTNET_ROOT/sdk/({$DOTNET_ROOT}/dotnet --version)/Sdks
set -gx PATH {$DOTNET_ROOT} $PATH
set -gx PATH ~/go/bin $PATH
set -x -U GOPATH $HOME/go

#Aliases
alias please="sudo"
alias gogit="cd ~/code/git"

#Ruby Gems
if which ruby > /dev/null && which gem > /dev/null
    set -gx PATH (ruby -r rubygems -e 'puts Gem.user_dir')/bin $PATH
end
