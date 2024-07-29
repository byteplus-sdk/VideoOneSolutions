import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import Home from './pages/Home';
import Pull from './pages/Pull';
import Push from './pages/Push';
import {Provider} from '@ant-design/react-native';
import Scan from './pages/Scan';
import PullDetail from './pages/Pull/detail';

const Stack = createNativeStackNavigator();

function App(): React.JSX.Element {
  return (
    <NavigationContainer>
      <Provider>
        <Stack.Navigator>
          <Stack.Group>
            <Stack.Screen
              name="Home"
              component={Home as React.FC}
              options={{title: 'Pull/Push'}}
            />
            <Stack.Screen
              name="Pull"
              component={Pull as React.FC}
              options={{title: 'Pull'}}
            />
            <Stack.Screen
              name="PullDetail"
              component={PullDetail as React.FC}
              options={{title: 'Pull Detail'}}
            />
            <Stack.Screen
              name="Push"
              component={Push as React.FC}
              options={{title: 'Push'}}
            />
          </Stack.Group>
          <Stack.Group
            screenOptions={{
              presentation: 'card',
              headerBackTitle: 'Close',
              headerBackVisible: true,
            }}>
            <Stack.Screen
              name="Scan"
              component={Scan as React.FC}
              options={{title: 'Scan'}}
            />
          </Stack.Group>
        </Stack.Navigator>
      </Provider>
    </NavigationContainer>
  );
}

export default App;
