import React, { useEffect, useState, Fragment } from 'react'
import { Grid, Icon, Label, List, Table } from 'semantic-ui-react'
// import {
//   Link,
// } from "react-router-dom";
import { useSubstrateState } from './substrate-lib'
import { hex_to_ascii } from './utilities'

function Main(props) {
  const { api, socket } = useSubstrateState()

  ////////////////node info
  // const [nodeInfo, setNodeInfo] = useState({})
  // useEffect(() => {
  //   const getInfo = async () => {
  //     try {
  //       const [chain, nodeName, nodeVersion] = await Promise.all([
  //         api.rpc.system.chain(),
  //         api.rpc.system.name(),
  //         api.rpc.system.version(),
  //       ])
  //       setNodeInfo({ chain, nodeName, nodeVersion })
  //     } catch (e) {
  //       console.error(e)
  //     }
  //   }
  //   getInfo()
  // }, [api.rpc.system])
  ////////////////end node info


  ////////////////block info
  // const { finalized } = props
  // const [blockNumber, setBlockNumber] = useState(0)
  // const [blockNumberTimer, setBlockNumberTimer] = useState(0)

  // const bestNumber = finalized
  //   ? api.derive.chain.bestNumberFinalized
  //   : api.derive.chain.bestNumber

  // useEffect(() => {
  //   let unsubscribeAll = null

  //   bestNumber(number => {
  //     // Append `.toLocaleString('en-US')` to display a nice thousand-separated digit.
  //     setBlockNumber(number.toNumber().toLocaleString('en-US'))
  //     setBlockNumberTimer(0)
  //   })
  //     .then(unsub => {
  //       unsubscribeAll = unsub
  //     })
  //     .catch(console.error)

  //   return () => unsubscribeAll && unsubscribeAll()
  // }, [bestNumber])

  // const timer = () => {
  //   setBlockNumberTimer(time => time + 1)
  // }

  // useEffect(() => {
  //   const id = setInterval(timer, 1000)
  //   return () => clearInterval(id)
  // }, [])
  ////////////////end block info

  ////////////////renault info
  const [renaultInfo, setRenaultInfo] = useState({})
  useEffect(() => {
    const getInfo = async () => {
      try {
        const [subscriptions] = await Promise.all([
          api.query.palletSimInsurance.subscriptions.entries(),
        ])
        setRenaultInfo({ subscriptions })
      } catch (e) {
        console.error(e)
      }
    }
    getInfo()
  }, [api, api.rpc.state])
  ////////////////end renault info


  function ListSubscriptions() {
    let elements = []
    if (renaultInfo.subscriptions && renaultInfo.subscriptions.length !== 0)
      // some magic to convert the storagekey to actual data:
      renaultInfo.subscriptions.map(([{ args: [driverid] }, value]) => {
        elements.push({ driverid: driverid, driverdata: value.toJSON()[0], blocknumber: value.toJSON()[1] })
        return true
      })
    elements.map((element, index) => {
      elements[index].driverdata_array = []
      for (let [key, value] of Object.entries(element.driverdata)) {
        if (key === "name" | key === "licenceCode")
          value = hex_to_ascii(elements[index].driverdata[key].toString().slice(2))
        elements[index].driverdata_array.push(<List.Item key={key}><u>{key}</u>: {value}</List.Item>)
      }
      return true
    })

    return elements && elements.length !== 0 ? (
      <Fragment>
        {elements.map((element) =>
          <Table.Row key={element.driverid.toString()}>
            <Table.Cell>{element.driverid.toString()} (<a href={`https://polkadot.js.org/apps/?rpc=${socket}#/explorer/query/${element.blocknumber.toString()}`} target="_blank" rel="noopener noreferrer"><Icon name="book" />{element.blocknumber.toString()}</a>)</Table.Cell>
            <Table.Cell>
              <List>
                {element.driverdata_array}
              </List>
              {/* <pre>{JSON.stringify(element.driverdata, null, 2)}</pre> */}
            </Table.Cell>
          </Table.Row>
        )}
      </Fragment>
    ) : (
      <Fragment>
        <Table.Row>
          <Table.Cell>
            <Label basic color="yellow">
              Nothing to be shown
            </Label>
          </Table.Cell>
          <Table.Cell></Table.Cell>
        </Table.Row>
      </Fragment>
    )
  }

  return (
    <Grid.Column>
      <Table celled>
        <Table.Header>
          <Table.Row>
            <Table.HeaderCell colSpan='4'>Insurance Dashboard</Table.HeaderCell>
          </Table.Row>
          <Table.Row>
            <Table.HeaderCell><Icon name="user" /> Driver ID</Table.HeaderCell>
            <Table.HeaderCell>Driver Subscription</Table.HeaderCell>
          </Table.Row>
        </Table.Header>
        <Table.Body>
          <ListSubscriptions />
        </Table.Body>
      </Table>
    </Grid.Column>
  )
}

export default function SIMInsuranceDashboard(props) {
  const { api } = useSubstrateState()
  return api.query.palletSimRenault &&
    api.rpc &&
    api.rpc.system &&
    api.rpc.system.chain &&
    api.rpc.system.name &&
    api.rpc.system.version &&
    api.derive &&
    api.derive.chain &&
    api.derive.chain.bestNumber &&
    api.derive.chain.bestNumberFinalized ? (
    <Main {...props} />
  ) : null
}
