import { createMuiTheme } from '@material-ui/core/styles';

const theme = createMuiTheme({
    palette: {
        primary: {
            light: '#67daff',
            main: '#03a9f4',
            dark: '#007ac1',
            contrastText: '#fff',
          },
          secondary: {
            light: '#ae52d4',
            main: '#7b1fa2',
            dark: '#4a0072',
            contrastText: '#fff',
          },
    },
  })

export default theme