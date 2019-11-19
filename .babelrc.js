module.exports = {
  presets: [
    ['@babel/preset-env', { useBuiltIns: 'usage' }],
    ['@babel/preset-react'],
  ],

  plugins: [
    [
      require.resolve('babel-plugin-module-resolver'),
      {
        alias: {
          React: './src/react',
        },
      },
    ],
  ],
};
