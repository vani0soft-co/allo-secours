const User = require('../models/User');
const jwt = require('jsonwebtoken');

const generateToken = (userId) => {
    return jwt.sign({ id: userId }, process.env.JWT_SECRET || 'secret', {
        expiresIn: process.env.JWT_EXPIRE || '7d',
    });
};

// Inscription
exports.register = async (req, res) => {
    try {
        const { firstName, lastName, email, password, passwordConfirm } = req.body;

        if (!firstName || !lastName || !email || !password) {
            return res.status(400).json({ success: false, error: 'Tous les champs sont requis' });
        }

        if (password !== passwordConfirm) {
            return res.status(400).json({ success: false, error: 'Les mots de passe ne correspondent pas' });
        }

        const existing = await User.findOne({ where: { email } });
        if (existing) {
            return res.status(400).json({ success: false, error: 'L\'email est déjà utilisé' });
        }

        const user = await User.create({ firstName, lastName, email, password });
        const token = generateToken(user.id);

        res.status(201).json({
            success: true,
            token,
            user: { id: user.id, firstName: user.firstName, lastName: user.lastName, email: user.email },
        });
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
};

// Connexion
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ success: false, error: 'Email et mot de passe requis' });
        }

        const user = await User.findOne({ where: { email } });
        if (!user) {
            return res.status(401).json({ success: false, error: 'Email ou mot de passe incorrect' });
        }

        const isValid = await user.comparePassword(password);
        if (!isValid) {
            return res.status(401).json({ success: false, error: 'Email ou mot de passe incorrect' });
        }

        const token = generateToken(user.id);

        res.json({
            success: true,
            token,
            user: { id: user.id, firstName: user.firstName, lastName: user.lastName, email: user.email },
        });
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
};

// Profil
exports.getProfile = async (req, res) => {
    try {
        const user = await User.findByPk(req.user.id, {
            attributes: { exclude: ['password'] },
        });
        res.json({ success: true, data: user });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

// Mettre à jour la localisation
exports.updateLocation = async (req, res) => {
    try {
        const { latitude, longitude } = req.body;
        await User.update(
            { lastLatitude: latitude, lastLongitude: longitude },
            { where: { id: req.user.id } }
        );
        res.json({ success: true });
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
};
