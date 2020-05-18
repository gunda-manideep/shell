original_image="microsoft/dotnet"
target_acr="myinternalacr.azurecr.io"
minimum_version="2.1"
grep_filter="deps|nanoserver|bionic|latest"


# Download all images
docker pull $original_image --all-tags

# Get all images published after $minimum_version
# format output to be: 
#   docker tag ORIGINAL_IMAGE_NAME:VERSION TARGET_IMAGE_NAME:VERSION |
#   docker push TARGET_IMAGE_NAME:VERSION
# then filter the result, removing any entries containing words defined on $grep_filter (i.e. rc, beta, alpha, etc)
# finally, execute those as commands
docker images $original_image \
  --filter "since=$original_image:$minimum_version" \
  --format "docker tag {{.Repository}}:{{.Tag}} $target_acr/{{.Repository}}:{{.Tag}} | docker push $target_acr/{{.Repository}}:{{.Tag}}" | 
  grep -vE $grep_filter | 
  bash