const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());
app.use('/uploads', express.static('uploads'));

// MongoDB Atlas Connection
mongoose.connect('mongodb+srv://shanto465islam:Iamgroot@cluster0.bd6pm.mongodb.net/campusconnect?retryWrites=true&w=majority&appName=Cluster0', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('Connected to MongoDB Atlas'))
  .catch((err) => console.error('MongoDB connection error:', err));

// Schemas
const userSchema = new mongoose.Schema({
  username: String,
  email: { type: String, unique: true },
  password: String,
  university: String,
  department: String,
  bloodGroup: String,
  phoneNumber: String, 
});

const lostItemSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  name: String,
  description: String,
  location: String,
  userEmail: String,
  imagePath: String,
  found: { type: Boolean, default: false },
});

const notificationSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  userEmail: String,
  message: String,
  timestamp: { type: Date, default: Date.now },
  finderEmail: String,
});

const User = mongoose.model('User', userSchema);
const LostItem = mongoose.model('LostItem', lostItemSchema);
const Notification = mongoose.model('Notification', notificationSchema);

// JWT Middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Access denied' });

    jwt.verify(token, 'shantoToken', (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = user;
    next();
  });
};

// Multer Setup for Image Upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, Date.now() + path.extname(file.originalname)),
});
const upload = multer({ storage });

// Routes
// Image Upload
app.post('/upload', authenticateToken, upload.single('image'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file uploaded' });
  res.status(200).json({ path: `/uploads/${req.file.filename}` });
});

// User Routes
app.post('/users/register', async (req, res) => {
  try {
    const { username, email, password, university, department, bloodGroup, phoneNumber } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({
      username,
      email,
      password: hashedPassword,
      university,
      department,
      bloodGroup,
      phoneNumber,
    });
    await user.save();
    res.status(201).json(user);
  } catch (error) {
    console.error('Error registering user:', error);
    res.status(500).json({ error: 'Failed to register user' });
  }
});

app.post('/users/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ error: 'User not found' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ error: 'Invalid credentials' });

    const token = jwt.sign({ email: user.email }, 'shantoToken', { expiresIn: '2d' });
    res.status(200).json({ token });
  } catch (error) {
    console.error('Error logging in:', error);
    res.status(500).json({ error: 'Failed to login' });
  }
});

app.get('/users/:email', authenticateToken, async (req, res) => {
  try {
    const user = await User.findOne({ email: req.params.email });
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.status(200).json(user);
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

app.patch('/users/:email/profile-picture', authenticateToken, async (req, res) => {
    try {
      const { profilePicture } = req.body;
      if (!profilePicture) return res.status(400).json({ error: 'Profile picture path required' });
  
      const user = await User.findOneAndUpdate(
        { email: req.params.email },
        { profilePicture },
        { new: true }
      );
      if (!user) return res.status(404).json({ error: 'User not found' });
      res.status(200).json(user);
    } catch (error) {
      console.error('Error updating profile picture:', error);
      res.status(500).json({ error: 'Failed to update profile picture' });
    }
  });

  app.delete('/users/:email', authenticateToken, async (req, res) => {
    try {
      const user = await User.findOne({ email: req.params.email });
      if (!user) return res.status(404).json({ error: 'User not found' });
      if (req.user.email !== req.params.email) return res.status(403).json({ error: 'Unauthorized' });
  
      // Delete associated data
      await LostItem.deleteMany({ userEmail: req.params.email });
      await Notification.deleteMany({ userEmail: req.params.email });
      await Notification.deleteMany({ finderEmail: req.params.email });
      await User.deleteOne({ email: req.params.email });
  
      res.status(200).json({ message: 'Account and associated data deleted' });
    } catch (error) {
      console.error('Error deleting account:', error);
      res.status(500).json({ error: 'Failed to delete account' });
    }
  });
  
// Lost Item Routes
app.post('/lost-items', authenticateToken, async (req, res) => {
  try {
    const lostItem = new LostItem(req.body);
    await lostItem.save();
    res.status(201).json(lostItem);
  } catch (error) {
    console.error('Error adding lost item:', error);
    res.status(500).json({ error: 'Failed to add lost item' });
  }
});

app.get('/lost-items', authenticateToken, async (req, res) => {
  try {
    const items = await LostItem.find();
    res.status(200).json(items);
  } catch (error) {
    console.error('Error fetching lost items:', error);
    res.status(500).json({ error: 'Failed to fetch lost items' });
  }
});

app.patch('/lost-items/:id', authenticateToken, async (req, res) => {
  try {
    const item = await LostItem.findOneAndUpdate({ id: req.params.id }, req.body, { new: true });
    if (!item) return res.status(404).json({ error: 'Item not found' });
    res.status(200).json(item);
  } catch (error) {
    console.error('Error updating lost item:', error);
    res.status(500).json({ error: 'Failed to update lost item' });
  }
});

app.delete('/lost-items/:id', authenticateToken, async (req, res) => {
  try {
    const item = await LostItem.findOne({ id: req.params.id });
    if (!item) return res.status(404).json({ error: 'Item not found' });
    if (item.userEmail !== req.user.email) return res.status(403).json({ error: 'Unauthorized' });
    await LostItem.deleteOne({ id: req.params.id });
    res.status(200).json({ message: 'Item deleted' });
  } catch (error) {
    console.error('Error deleting lost item:', error);
    res.status(500).json({ error: 'Failed to delete lost item' });
  }
});

// Notification Routes
app.post('/notifications', authenticateToken, async (req, res) => {
  try {
    const notificationData = {
      ...req.body,
      timestamp: req.body.timestamp ? new Date(req.body.timestamp) : new Date(),
    };
    const notification = new Notification(notificationData);
    await notification.save();
    res.status(201).json(notification);
  } catch (error) {
    console.error('Error adding notification:', error);
    res.status(500).json({ error: 'Failed to add notification' });
  }
});

app.get('/notifications/:userEmail', authenticateToken, async (req, res) => {
  try {
    const notifications = await Notification.find({ userEmail: req.params.userEmail });
    res.status(200).json(notifications);
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});