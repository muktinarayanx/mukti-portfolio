# Fuel Data Management and Billing Website

A full-stack secure web application to log fuel transactions, view history, and generate dynamic PDF bills.

## Tech Stack
- **Frontend**: Vanilla HTML, CSS, JavaScript
- **Backend**: Node.js, Express.js
- **Database**: MongoDB Atlas and Mongoose
- **Security**: JWT Authentication, bcrypt password hashing
- **PDF Generation**: pdfkit

---

## 🚀 Setup Instructions

### 1. Configure MongoDB Atlas
To run this application, you must connect it to a MongoDB Atlas cluster.
1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) and create an account or sign in.
2. Build a new cluster (the free shared tier is fine).
3. Once the cluster is created, click **"Connect"**.
4. Set up an Database User with a **username** and **password**. (Remember this password).
5. Choose **"Connect your application"** under connection methods.
6. Copy the connection string. It will look something like this:
   `mongodb+srv://<username>:<password>@cluster0.mongodb.net/?retryWrites=true&w=majority`
7. Replace `<password>` with the password you created in step 4.

### 2. Environment Variables
1. Open the `.env` file in the root of the project.
2. Paste your MongoDB connection string into the `MONGO_URI` variable:
   ```env
   MONGO_URI=your_copied_connection_string_here
   JWT_SECRET=yoursecretkey_changethis_for_production
   PORT=5000
   ```

### 3. Install Dependencies and Run Locally
Open your terminal in the `new_project` directory and run the following commands:

```bash
# Verify you are in the new_project directory
cd path/to/new_project

# Install all backend dependencies
npm install

# Start the Node.js server
node server.js
```

### 4. Access the Application
1. Open your web browser and go to: `http://localhost:5000`
2. You will be redirected to the **Login** page.
3. Click "Register here" to create a new user account.
4. Log in with your new credentials.
5. You can now add fuel records, view them in the dashboard, and click "Download Bill" to dynamically generate a PDF receipt for any transaction.
