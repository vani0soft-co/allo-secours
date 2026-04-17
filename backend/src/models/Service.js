const { DataTypes } = require('sequelize');
const sequelize = require('./index');

const Service = sequelize.define('Service', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    name: {
        type: DataTypes.STRING(100),
        allowNull: false,
    },
    category: {
        type: DataTypes.ENUM('hospital', 'pharmacy', 'specialist', 'emergency', 'imaging'),
        allowNull: false,
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    address: {
        type: DataTypes.STRING(255),
        allowNull: false,
    },
    city: {
        type: DataTypes.STRING(100),
        allowNull: false,
    },
    zipCode: {
        type: DataTypes.STRING(20),
        allowNull: false,
    },
    country: {
        type: DataTypes.STRING(100),
        defaultValue: 'France',
    },
    latitude: {
        type: DataTypes.DOUBLE,
        allowNull: false,
    },
    longitude: {
        type: DataTypes.DOUBLE,
        allowNull: false,
    },
    phone: {
        type: DataTypes.STRING(20),
        allowNull: false,
    },
    email: {
        type: DataTypes.STRING(255),
        allowNull: true,
    },
    website: {
        type: DataTypes.STRING(255),
        allowNull: true,
    },
    workingHours: {
        type: DataTypes.STRING(100),
        defaultValue: '9h-18h',
    },
    isOpen: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
    },
    rating: {
        type: DataTypes.FLOAT,
        defaultValue: 0,
    },
    reviewCount: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    specialties: {
        type: DataTypes.TEXT,
        allowNull: true,
        get() {
            const val = this.getDataValue('specialties');
            return val ? JSON.parse(val) : [];
        },
        set(val) {
            this.setDataValue('specialties', JSON.stringify(val || []));
        },
    },
    services: {
        type: DataTypes.TEXT,
        allowNull: true,
        get() {
            const val = this.getDataValue('services');
            return val ? JSON.parse(val) : [];
        },
        set(val) {
            this.setDataValue('services', JSON.stringify(val || []));
        },
    },
    emergencyServices: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    verified: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
}, {
    tableName: 'services',
    timestamps: true,
});

module.exports = Service;
