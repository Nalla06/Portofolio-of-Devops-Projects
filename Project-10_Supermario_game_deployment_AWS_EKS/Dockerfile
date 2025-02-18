# Use an official Node.js runtime as a parent image
FROM node:16-alpine

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json for dependencies
COPY package*.json ./

# Verify that the package.json files are copied
RUN ls -l

# Install any dependencies the app requires
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port the app will run on
EXPOSE 3000

# Define the command to run the app
CMD ["npm", "start"]