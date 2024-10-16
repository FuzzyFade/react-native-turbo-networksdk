import { useState, useEffect } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import { updateTurboNetworksConfiguration } from 'react-native-turbo-networksdk';

export default function App() {
  const [result, setResult] = useState<number | undefined>();

  useEffect(() => {
    updateTurboNetworksConfiguration(true).then(
      (response) => setResult(response),
      (error) => console.error(error)
    );
  }, []);

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
