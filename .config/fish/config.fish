set -gx DOTNET_ROOT /opt/dotnet
set -gx MSBuildSDKsPath $DOTNET_ROOT/sdk/({$DOTNET_ROOT}/dotnet --version)/Sdks
set -gx PATH {$DOTNET_ROOT} $PATH
set -gx PATH ~/go/bin $PATH
set -x -U GOPATH $HOME/go
