FROM node:18

WORKDIR /usr/src/app

COPY package*.json ./

RUN apt-get update && apt-get install -y wait-for-it
RUN npm install && npm install -g webpack webpack-cli

COPY . .

#RUN npm run build

EXPOSE 3000

#CMD ["npm", "start"]
CMD ["wait-for-it", "mysql:3306", "--", "npm", "start"]
