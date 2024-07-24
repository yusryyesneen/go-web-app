#Using go lang base image in base stage
FROM golang:1.22.5 as base

# Set the working directory to /app. Now all the commands after WORKDIR will execute inside /app directory 
WORKDIR /app     

#dependencies thats required for go application to run are stored in go.mod file..we copy the go.mod file from our local directory to inside the image /app
COPY go.mod .

#this command is used to download the dependencies specified in go.mod file
RUN go mod download

#copying the source code and all the other files onto /app direcory in the docker image (source(local directory): destination(dockerimage) )
COPY . .

#this command will build and create an artificat/binary called "main" inside /app directory in the dokcer image
RUN go build -o main . 


# Final Stage - Distroless Image.

#Reduced Size: Distroless images are much smaller because they exclude unnecessary packages and libraries.
#Improved Security: Fewer packages mean fewer potential vulnerabilities, reducing the attack surface.
#Faster Deployment: Smaller images can be pulled and deployed more quickly.

FROM gcr.io/distroless/base

#copying the binary "main" from /app directory inside docker image (that got built in base stage) to /root  directory (which is the default directory . in docker image)...We can create any working directory no need to have default directory
COPY --from=base /app/main .

#we need static files(html,css files) as well... So we copy static files which is already inside /app to new working directory called /static...Static files are not bundled with your "main"
COPY --from=base /app/static ./static

#exposing the port
EXPOSE 8080

#run the application by executing main
CMD [ "./main" ]